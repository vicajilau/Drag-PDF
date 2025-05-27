# Contributing to Drag PDF

First of all, thank you for considering contributing to Drag PDF — your help is essential to making this project better!

The following guidelines aim to ensure a smooth and respectful collaboration process.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Style Guide](#style-guide)
- [Submitting a Pull Request](#submitting-a-pull-request)
- [Reporting Issues](#reporting-issues)
- [Questions](#questions)

## Code of Conduct

We are committed to fostering a welcoming and inclusive environment for everyone.

By participating in this project, you agree to:
- Be respectful and considerate of others.
- Use inclusive and constructive language.
- Report any abusive, harassing, or otherwise unacceptable behavior.

Harassment, discrimination, or personal attacks of any kind will not be tolerated. Let's work together to make Drag PDF a positive space for collaboration and learning.

## Getting Started

To set up the project locally:

```bash
git clone https://github.com/vicajilau/Drag-PDF
cd drag-pdf
flutter pub get
```

To run the project:

```bash
flutter run -d chrome
```

## How to Contribute

You can contribute in many ways:

- 💡 Suggest new features or enhancements
- 🐛 Report bugs or edge cases
- 🧪 Add or improve tests
- 📝 Improve the documentation
- 💄 Refactor or optimize existing code

To get started, check the [Issues](https://github.com/your-username/drag-pdf/issues) section. Look for labels such as `good first issue` or `help wanted`.

## Style Guide

- Format your code using `dart format .` before committing.
- Follow best practices from [Effective Dart](https://dart.dev/guides/language/effective-dart).
- Keep your code readable and documented.
- Add comments where logic is complex or non-obvious.
- Favor clarity over cleverness.

## Submitting a Pull Request

1. Fork this repository and create a new branch from `main`.
2. Make your changes in the branch.
3. Ensure everything builds and passes:
   ```bash
   flutter analyze
   flutter test
   ```
4. Commit your changes with a descriptive message. Good commit messages briefly summarize what changed and why (e.g. `fix: handle null path in file picker result`).
5. Push your branch to your forked repository.
6. Open a Pull Request (PR) against the `main` branch of this repository.
7. In the PR description:
    - Clearly explain **what** the change does.
    - Justify **why** the change is needed or how it improves the project.
    - Include screenshots or demo steps if your PR affects the UI or user experience.
    - Reference related issues by number (e.g. `Closes #42`).

Once submitted:
- A maintainer will review your PR.
- You might be asked to make changes before the PR can be merged.
- Try to respond to feedback quickly to keep things moving.

## Reporting Issues

When reporting a bug, please include:

- A short, descriptive title.
- Clear steps to reproduce the issue.
- What you expected to happen.
- What actually happened instead.
- Any relevant logs, screenshots, or browser/device information.

This helps us reproduce and fix the issue more efficiently.

## Code of Conduct

We’re committed to fostering a friendly and inclusive environment.

By contributing to this project, you agree to:

- Treat everyone with respect and empathy.
- Avoid offensive, derogatory, or discriminatory language.
- Collaborate in good faith.

Unacceptable behavior will result in a warning or ban from the project depending on the severity.

## Questions

If you have any doubts or ideas:
- Open an issue or discussion in the repo.
- Reach out to a maintainer via GitHub if you need clarification before contributing.

We appreciate your support and look forward to your contributions! 💙
