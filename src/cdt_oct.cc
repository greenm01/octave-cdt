#include <octave/oct.h>

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

extern "C" {
#include "p2t.h"
}

namespace
{
  struct ContextDeleter
  {
    void operator () (p2t_context *ctx) const
    {
      p2t_destroy (ctx);
    }
  };

  using ContextPtr = std::unique_ptr<p2t_context, ContextDeleter>;

  Matrix require_points_matrix (const octave_value& value, const char *name)
  {
    Matrix m = value.xmatrix_value ("%s must be a real numeric matrix", name);

    if (m.columns () != 2)
      error ("%s must have exactly two columns", name);

    return m;
  }

  std::vector<p2t_vec2> to_points (const Matrix& m)
  {
    std::vector<p2t_vec2> points;
    points.reserve (m.rows ());

    for (octave_idx_type i = 0; i < m.rows (); i++)
      points.push_back (p2t_vec2 { m(i, 0), m(i, 1) });

    return points;
  }

  std::vector<p2t_edge> to_edges (const Matrix& m, const char *name)
  {
    if (m.columns () != 2)
      error ("%s must have exactly two columns", name);

    std::vector<p2t_edge> edges;
    edges.reserve (m.rows ());

    for (octave_idx_type i = 0; i < m.rows (); i++)
      {
        int32_t a = static_cast<int32_t> (m(i, 0)) - 1;
        int32_t b = static_cast<int32_t> (m(i, 1)) - 1;
        edges.push_back (p2t_edge { a, b });
      }

    return edges;
  }

  bool bool_arg (const octave_value& value, const char *name)
  {
    if (! value.islogical () && ! value.isnumeric ())
      error ("%s must be a logical or numeric scalar", name);

    return value.bool_value ();
  }

  p2t_contour make_contour (int32_t id, const std::vector<p2t_vec2>& points)
  {
    return p2t_contour {
      id,
      points.empty () ? nullptr : points.data (),
      static_cast<int32_t> (points.size ())
    };
  }

  Matrix triangles_to_matrix (const p2t_result& result)
  {
    Matrix tri (result.triangle_count, 3);

    for (int32_t i = 0; i < result.triangle_count; i++)
      {
        tri(i, 0) = result.triangles[i].a + 1;
        tri(i, 1) = result.triangles[i].b + 1;
        tri(i, 2) = result.triangles[i].c + 1;
      }

    return tri;
  }

  Matrix vertices_to_matrix (const p2t_result& result)
  {
    Matrix vertices (result.vertex_count, 2);

    for (int32_t i = 0; i < result.vertex_count; i++)
      {
        vertices(i, 0) = result.vertices[i].x;
        vertices(i, 1) = result.vertices[i].y;
      }

    return vertices;
  }

  Matrix edges_to_matrix (const p2t_result& result)
  {
    Matrix edges (result.boundary_edge_count, 2);

    for (int32_t i = 0; i < result.boundary_edge_count; i++)
      {
        edges(i, 0) = result.boundary_edges[i].a + 1;
        edges(i, 1) = result.boundary_edges[i].b + 1;
      }

    return edges;
  }

  void check_result (const p2t_result& result)
  {
    if (result.ok)
      return;

    std::string message = result.error.message ? result.error.message : "unknown CDT error";
    error ("p2t: %s (kind=%d, contour_id=%d, point_index=%d)",
           message.c_str (), result.error.kind, result.error.contour_id,
           result.error.point_index);
  }
}

DEFUN_DLD (cdt_oct, args, nargout,
           "[tri, vertices, boundary_edges] = cdt_oct (outer, holes, steiner, epsilon, clean_input, validate, keep_boundary_edges, mode)")
{
  if (args.length () != 8)
    print_usage ();

  Matrix outer_matrix = require_points_matrix (args(0), "outer");
  std::vector<p2t_vec2> outer_points = to_points (outer_matrix);
  p2t_contour outer = make_contour (0, outer_points);

  if (! args(1).iscell ())
    error ("holes must be a cell array of Nx2 matrices");

  Cell hole_cells = args(1).cell_value ();
  std::vector<std::vector<p2t_vec2>> hole_points;
  std::vector<p2t_contour> holes;
  hole_points.reserve (hole_cells.numel ());
  holes.reserve (hole_cells.numel ());

  for (octave_idx_type i = 0; i < hole_cells.numel (); i++)
    {
      Matrix hole_matrix = require_points_matrix (hole_cells(i), "hole");
      hole_points.push_back (to_points (hole_matrix));
      holes.push_back (make_contour (static_cast<int32_t> (i + 1),
                                     hole_points.back ()));
    }

  Matrix steiner_matrix = require_points_matrix (args(2), "steiner");
  std::vector<p2t_vec2> steiner = to_points (steiner_matrix);

  double epsilon = args(3).xdouble_value ("epsilon must be a scalar");
  bool clean_input = bool_arg (args(4), "clean_input");
  bool validate = bool_arg (args(5), "validate");
  bool keep_boundary_edges = bool_arg (args(6), "keep_boundary_edges");
  std::string mode = args(7).xstring_value ("mode must be a string");

  ContextPtr ctx (p2t_create ());
  if (! ctx)
    error ("p2t_create failed");

  p2t_result result;
  const p2t_contour *hole_ptr = holes.empty () ? nullptr : holes.data ();
  const p2t_vec2 *steiner_ptr = steiner.empty () ? nullptr : steiner.data ();

  if (mode == "checked")
    {
      p2t_options options = p2t_default_options ();
      options.epsilon = epsilon;
      options.clean_input = clean_input ? 1 : 0;
      options.validate = validate ? 1 : 0;
      options.keep_boundary_edges = keep_boundary_edges ? 1 : 0;

      result = p2t_tessellate (ctx.get (), outer, hole_ptr,
                               static_cast<int32_t> (holes.size ()),
                               steiner_ptr,
                               static_cast<int32_t> (steiner.size ()),
                               &options);
    }
  else if (mode == "trusted")
    {
      result = p2t_tessellate_trusted (ctx.get (), outer, hole_ptr,
                                       static_cast<int32_t> (holes.size ()),
                                       steiner_ptr,
                                       static_cast<int32_t> (steiner.size ()),
                                       epsilon);
    }
  else if (mode == "normalized_trusted")
    {
      result = p2t_tessellate_normalized_trusted (
        ctx.get (), outer, hole_ptr, static_cast<int32_t> (holes.size ()),
        steiner_ptr, static_cast<int32_t> (steiner.size ()), epsilon);
    }
  else
    error ("mode must be \"checked\", \"trusted\", or \"normalized_trusted\"");

  check_result (result);

  octave_value_list out;
  out(0) = triangles_to_matrix (result);

  if (nargout >= 2)
    out(1) = vertices_to_matrix (result);

  if (nargout >= 3)
    out(2) = edges_to_matrix (result);

  return out;
}


DEFUN_DLD (cdt_pointset_oct, args, nargout,
           "[tri, vertices] = cdt_pointset_oct (points, boundary_segments, segments, holes, epsilon)")
{
  if (args.length () < 1 || args.length () > 5)
    print_usage ();

  Matrix point_matrix = require_points_matrix (args(0), "points");
  std::vector<p2t_vec2> points = to_points (point_matrix);

  Matrix boundary_matrix;
  if (args.length () >= 2 && ! args(1).isempty ())
    boundary_matrix = args(1).xmatrix_value ("boundary_segments must be a real numeric matrix");
  else
    boundary_matrix = Matrix (0, 2);

  Matrix segment_matrix;
  if (args.length () >= 3 && ! args(2).isempty ())
    segment_matrix = args(2).xmatrix_value ("segments must be a real numeric matrix");
  else
    segment_matrix = Matrix (0, 2);

  Matrix hole_matrix;
  if (args.length () >= 4 && ! args(3).isempty ())
    hole_matrix = require_points_matrix (args(3), "holes");
  else
    hole_matrix = Matrix (0, 2);

  double epsilon = 1e-9;
  if (args.length () >= 5 && ! args(4).isempty ())
    epsilon = args(4).xdouble_value ("epsilon must be a scalar");

  std::vector<p2t_edge> boundary_segments
    = to_edges (boundary_matrix, "boundary_segments");
  std::vector<p2t_edge> segments = to_edges (segment_matrix, "segments");
  std::vector<p2t_vec2> holes = to_points (hole_matrix);

  ContextPtr ctx (p2t_create ());
  if (! ctx)
    error ("p2t_create failed");

  p2t_result result = p2t_tessellate_pslg (
    ctx.get (), points.empty () ? nullptr : points.data (),
    static_cast<int32_t> (points.size ()),
    boundary_segments.empty () ? nullptr : boundary_segments.data (),
    static_cast<int32_t> (boundary_segments.size ()),
    segments.empty () ? nullptr : segments.data (),
    static_cast<int32_t> (segments.size ()),
    holes.empty () ? nullptr : holes.data (),
    static_cast<int32_t> (holes.size ()), epsilon);

  check_result (result);

  octave_value_list out;
  out(0) = triangles_to_matrix (result);

  if (nargout >= 2)
    out(1) = vertices_to_matrix (result);

  return out;
}
