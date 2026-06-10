# Homebrew Formula

`octave-cdt.rb.in` is a formula template for a future Homebrew tap.

To publish:

1. Tag and publish `p2t`.
2. Tag and publish `octave-cdt`.
3. Replace `REPLACE_WITH_OWNER`, source URLs, and SHA256 values in the template.
4. Copy the rendered formula to a tap as `Formula/octave-cdt.rb`.
5. Test with:

```sh
brew install --build-from-source ./Formula/octave-cdt.rb
brew test octave-cdt
```

The formula installs files under `share/octave-cdt` and provides
`cdt_setup.m`. Users can load the package from Octave with:

```octave
source ("/opt/homebrew/opt/octave-cdt/share/octave-cdt/cdt_setup.m");
```

For Intel Homebrew installs, the prefix is usually `/usr/local` instead of
`/opt/homebrew`.

