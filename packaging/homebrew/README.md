# Homebrew Formula

`octave-cdt.rb.in` is a template for a future Homebrew tap formula.

Release steps:

1. Tag and publish `p2t`.
2. Tag and publish `octave-cdt`.
3. Replace `REPLACE_WITH_OWNER`, the source URLs, and the SHA256 values in the template.
4. Copy the rendered file to the tap as `Formula/octave-cdt.rb`.
5. Test the formula:

```sh
brew install --build-from-source ./Formula/octave-cdt.rb
brew test octave-cdt
```

The formula installs the package under `share/octave-cdt` and writes a
`cdt_setup.m` file. Users can add it to `~/.octaverc` with:

```sh
echo "source (\"$(brew --prefix octave-cdt)/share/octave-cdt/cdt_setup.m\");" >> ~/.octaverc
```
