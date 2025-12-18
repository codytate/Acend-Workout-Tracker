# Contributing to Gainz

Thank you for your interest in contributing to Gainz! We welcome contributions from the community and appreciate your help in making this Swift project better.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Commit Guidelines](#commit-guidelines)
- [Submitting Pull Requests](#submitting-pull-requests)
- [Code Style](#code-style)
- [Testing](#testing)

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Getting Started

### Prerequisites

- macOS or Linux system with Swift development tools installed
- Xcode 12.0 or later (for macOS development)
- Git

### Forking the Repository

1. Navigate to the [Gainz repository](https://github.com/codytate/Gainz)
2. Click the **Fork** button in the top-right corner
3. This creates a copy of the repository under your GitHub account

### Cloning Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/Gainz.git
cd Gainz
```

### Adding Upstream Remote

To keep your fork in sync with the original repository, add an upstream remote:

```bash
git remote add upstream https://github.com/codytate/Gainz.git
git remote -v  # Verify remotes
```

## How to Contribute

### Types of Contributions

- **Bug Fixes**: Fix existing issues in the codebase
- **Features**: Add new functionality to Gainz
- **Documentation**: Improve or create documentation
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing code

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work. Never commit directly to `main`:

```bash
# Update your local main branch
git fetch upstream
git checkout main
git merge upstream/main

# Create a new feature branch
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - for new features
- `bugfix/` - for bug fixes
- `docs/` - for documentation updates
- `test/` - for test improvements
- `refactor/` - for code refactoring

### 2. Make Your Changes

Edit the files as needed. Keep your changes focused and atomic.

### 3. Build and Test Locally

```bash
# Build the project
swift build

# Run tests
swift test

# For Xcode projects
xcodebuild build
xcodebuild test
```

## Commit Guidelines

### Commit Message Format

Write clear, descriptive commit messages following this format:

```
<type>: <subject>

<body>

<footer>
```

### Type

Must be one of the following:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (formatting, missing semicolons, etc.)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process, dependencies, tooling, or configuration

### Subject

- Use the imperative mood ("add" not "adds" or "added")
- Do not capitalize the first letter
- Do not include a period (.) at the end
- Limit to 50 characters or less

### Body (Optional)

- Wrap at 72 characters
- Explain what and why, not how
- Separate from subject with a blank line

### Footer (Optional)

Reference any relevant issues:

```
Fixes #123
Relates to #456
```

### Example Commits

```
feat: add calorie tracking feature

Implement calorie tracking functionality to allow users to log
daily calorie intake. This includes a new CalorieLogger class
and integration with the main UI.

Fixes #42
```

```
fix: correct calculation in weight converter

The weight converter was using incorrect conversion factor.
Updated from 2.2 to 2.20462 for accurate pound to kilogram conversion.

Fixes #89
```

## Submitting Pull Requests

### Before You Start

1. Ensure your branch is up-to-date with the latest upstream changes:

```bash
git fetch upstream
git rebase upstream/main
```

2. Run tests locally:

```bash
swift test
```

### Opening a Pull Request

1. Push your branch to your fork:

```bash
git push origin feature/your-feature-name
```

2. Navigate to the original [Gainz repository](https://github.com/codytate/Gainz)

3. Click **New Pull Request**

4. Select your fork and branch as the source, and `main` as the target

5. Fill out the PR template with:
   - **Title**: A clear, concise description of changes
   - **Description**: Explain what the PR does and why
   - **Related Issues**: Link to any related issues (e.g., `Fixes #42`)
   - **Testing**: Describe how you tested the changes
   - **Screenshots/Videos**: If applicable, include visual demonstrations

### PR Best Practices

- Keep PRs focused on a single issue or feature
- Keep the number of commits reasonable and meaningful
- Include tests for new functionality
- Update documentation as needed
- Respond promptly to review feedback
- Be respectful and constructive in discussions

### After Submission

- The CI/CD pipeline will run automatically
- Maintainers and community members will review your PR
- Respond to feedback and make requested changes
- Once approved, your PR will be merged by a maintainer

## Code Style

### Swift Style Guidelines

- Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation (not tabs)
- Use meaningful variable and function names
- Keep lines under 100 characters when possible
- Use type inference where appropriate, but be explicit when it improves clarity

### Example

```swift
// Good
func calculateTotalCalories(for meal: Meal) -> Int {
    return meal.items.reduce(0) { total, item in
        total + item.calories
    }
}

// Avoid
func calc(_ m: Meal) -> Int {
    var t = 0
    for i in m.items {
        t = t + i.calories
    }
    return t
}
```

## Testing

### Writing Tests

- Add unit tests for all new functionality
- Use meaningful test names that describe what is being tested
- Aim for good coverage but focus on critical paths

### Example Test

```swift
import XCTest
@testable import Gainz

class WeightTrackerTests: XCTestCase {
    func testAddWeightReading() {
        let tracker = WeightTracker()
        tracker.addReading(weight: 180, date: Date())
        
        XCTAssertEqual(tracker.latestReading?.weight, 180)
    }
}
```

### Running Tests

```bash
swift test
# or
xcodebuild test
```

## Getting Help

- Check the [README](README.md) for general information
- Review existing [Issues](https://github.com/codytate/Gainz/issues) and [Pull Requests](https://github.com/codytate/Gainz/pulls)
- Open a new issue for bugs or feature requests
- Join discussions or reach out to maintainers if you need clarification

## License

By contributing to Gainz, you agree that your contributions will be licensed under the project's license. Please check the [LICENSE](LICENSE) file for details.

---

Thank you for contributing to Gainz! 🎉
