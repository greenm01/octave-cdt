# octave-cdt

GNU Octave bindings for `p2t`, a 2D constrained Delaunay tessellator.

This package exposes a polygon-oriented CDT function:

```octave
outer = [0 0; 1 0; 1 1; 0 1];
[tri, vertices] = cdt (outer);
triplot (tri, vertices(:,1), vertices(:,2));
```

Holes and Steiner points are optional:

```octave
outer = [0 0; 4 0; 4 4; 0 4];
hole = [1 1; 1 2; 2 2; 2 1];
steiner = [3 3];
[tri, vertices, boundary_edges] = cdt (outer, {hole}, steiner,
                                      struct ("keep_boundary_edges", true));
```

Octave-style NaN-separated polygon matrices are also accepted. The first ring is
the outer contour; later rings are holes:

```octave
polygon = [outer; NaN NaN; hole];
[tri, vertices] = cdt (polygon);
```

Contours are closed by the library. Do not repeat the first point at the end.
Triangle and edge indices returned to Octave are 1-based.

## Build

Build the `p2t` C ABI first:

```sh
cd ../p2t
nimble buildCAbi
```

Then build the Octave module:

```sh
cd ../octave-cdt
make
```

If `p2t` is not next to this checkout, set `P2T_DIR`:

```sh
make P2T_DIR=/path/to/p2t
```

The build expects the C ABI library at `/tmp/libp2t.dylib` on macOS or
`/tmp/libp2t.so` on Linux, matching the current `p2t` nimble task.

## Install

For a local install:

```sh
make install PREFIX=$HOME/.local
```

Then load the package paths from Octave:

```octave
source (fullfile (getenv ("HOME"), ".local", "share", "octave-cdt", "cdt_setup.m"));
```

For Homebrew distribution, use [packaging/homebrew/octave-cdt.rb.in](packaging/homebrew/octave-cdt.rb.in)
as the tap formula template. After publishing tagged tarballs for `octave-cdt`
and `p2t`, replace the template URLs and SHA256 values, then install from the
tap with:

```sh
brew install octave-cdt
```

The formula installs `cdt_setup.m`; users can add this to `~/.octaverc`:

```sh
echo "source (\"$(brew --prefix octave-cdt)/share/octave-cdt/cdt_setup.m\");" >> ~/.octaverc
```

## Smoke Test

```sh
make test
```

## Examples

```sh
octave --path inst --path examples --path examples/fixtures --eval "demo_star"
octave --path inst --path examples --path examples/fixtures --eval "demo_polygon_with_hole"
octave --path inst --path examples --path examples/fixtures --eval "check_fixtures"
```

## API

```octave
[tri, vertices] = cdt (outer)
[tri, vertices] = cdt (outer, holes)
[tri, vertices] = cdt (outer, holes, steiner)
[tri, vertices, boundary_edges] = cdt (outer, holes, steiner, options)
```

- `outer`: `N x 2` numeric matrix.
- `outer`: may also be a NaN-separated `N x 2` numeric matrix containing the outer ring followed by holes.
- `holes`: cell array of `N x 2` numeric matrices, one `N x 2` matrix, a NaN-separated `N x 2` matrix, or `{}`.
- `steiner`: `N x 2` numeric matrix, or `[]`.
- `options.epsilon`: geometric tolerance, default `1e-9`.
- `options.clean_input`: remove adjacent duplicates, closing duplicate, and collinear contour points, default `true`.
- `options.validate`: validate input contours, default `true`.
- `options.keep_boundary_edges`: return boundary edges, default `nargout >= 3`.
- `options.mode`: `"checked"`, `"trusted"`, or `"normalized_trusted"`, default `"checked"`.
