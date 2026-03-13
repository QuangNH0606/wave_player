# Contributing to Wave Player

## Development Setup

```bash
git clone https://github.com/QuangNH0606/wave_player.git
cd wave_player
flutter pub get
```

## Workflow

1. Fork & create branch from `main`
2. Make changes
3. Ensure all checks pass:

```bash
dart format .
flutter analyze
flutter test
```

4. Update `CHANGELOG.md` if user-facing
5. Open PR → CI must pass → Wait for review

## Code Standards

- Follow `analysis_options.yaml` lint rules
- Add doc comments to all public APIs (`public_member_api_docs`)
- Write tests for new features

## Releases

Maintainers only:

1. Update `version` in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Merge to `main`
4. Tag: `git tag vX.X.X && git push --tags`
5. Publish: `dart pub publish`

## Questions?

Open an [issue](https://github.com/QuangNH0606/wave_player/issues).
