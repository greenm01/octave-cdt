root = fileparts (mfilename ("fullpath"));
addpath (fullfile (root, "..", "inst"));
addpath (fullfile (root, "fixtures"));

run_fixture ("test", test_fixture ());
run_fixture ("diamond", diamond_fixture ());
run_fixture ("star", star_fixture ());
run_fixture ("strange", strange_fixture ());
run_fixture ("dude", dude_fixture ());
run_fixture ("dude-with-holes", dude_with_holes_fixture ());
run_fixture ("stalactite-with-hole", stalactite_with_hole_fixture ());
run_fixture ("nazca-heron", nazca_heron_fixture ());
