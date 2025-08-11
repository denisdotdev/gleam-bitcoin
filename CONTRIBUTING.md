# Contributing to Gleam Bitcoin

Thank you for your interest in contributing to the Gleam Bitcoin library! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- [Gleam](https://gleam.run/getting-started/) installed
- [Erlang/OTP](https://www.erlang.org/) (required by Gleam)
- Git for version control

### Development Setup

1. Fork and clone the repository:
   ```sh
   git clone https://github.com/your-username/gleam-bitcoin.git
   cd gleam-bitcoin
   ```

2. Install dependencies:
   ```sh
   gleam deps download
   ```

3. Run tests to verify setup:
   ```sh
   gleam test
   ```

4. Build the project:
   ```sh
   gleam build
   ```

## Development Guidelines

### Code Style

- Follow standard Gleam formatting conventions
- Use `gleam format` to ensure consistent code style
- Write descriptive function and variable names
- Include type annotations where helpful for clarity

### Project Structure

- `src/` - Main library code
  - `address.gleam` - Address generation and validation
  - `bitcoin.gleam` - Main public API
  - `transaction.gleam` - Transaction building and serialization
  - `encoding/` - Encoding utilities (Base58, Bech32, hex)
  - `types/` - Type definitions and constants
- `test/` - Test files
- `examples/` - Example usage code

### Testing

- Write comprehensive tests for all new functionality
- Use descriptive test names that explain what is being tested
- Test both success and error cases
- Run tests with: `gleam test`
- Ensure all tests pass before submitting changes

### Documentation

- Document all public functions with clear descriptions
- Include parameter types and return types
- Provide usage examples for complex functions
- Update README.md if adding new features
- Follow Gleam documentation conventions

## Contributing Process

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use the issue template if available
3. Provide clear reproduction steps
4. Include relevant system information (Gleam version, OS, etc.)

### Making Changes

1. Create a new branch for your feature/fix:
   ```sh
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the guidelines above

3. Add or update tests as needed

4. Ensure all tests pass:
   ```sh
   gleam test
   ```

5. Format your code:
   ```sh
   gleam format
   ```

6. Commit your changes with clear, descriptive messages:
   ```sh
   git commit -m "Add support for P2TR addresses"
   ```

### Pull Request Guidelines

1. Push your branch and create a pull request
2. Use a clear, descriptive title
3. Provide a detailed description of changes
4. Reference any related issues
5. Ensure CI passes
6. Be responsive to feedback and make requested changes

## Security Considerations

This library handles Bitcoin-related cryptographic operations. When contributing:

- Never commit test private keys or real Bitcoin data
- Be careful with cryptographic implementations
- Follow Bitcoin protocol specifications precisely
- Consider security implications of any changes
- Report security issues privately to maintainers

## Code Review Process

1. All changes require review from maintainers
2. Reviews focus on:
   - Correctness and Bitcoin protocol compliance
   - Code quality and style
   - Test coverage
   - Documentation completeness
   - Security implications

3. Address feedback promptly and professionally
4. Changes may require multiple review rounds

## Types of Contributions

We welcome various types of contributions:

- **Bug fixes** - Fix incorrect behavior or edge cases
- **New features** - Add Bitcoin protocol support (new address types, etc.)
- **Documentation** - Improve docs, examples, or guides
- **Tests** - Add test coverage for existing functionality
- **Performance** - Optimize existing implementations
- **Examples** - Add practical usage examples

## Bitcoin Protocol Guidelines

When implementing Bitcoin functionality:

- Follow Bitcoin protocol specifications exactly
- Reference official Bitcoin documentation
- Test against known test vectors when available
- Consider compatibility with major Bitcoin implementations
- Support all relevant networks (mainnet, testnet, signet, regtest)

## Questions and Support

- For questions about contributing, open an issue with the "question" label
- For general usage questions, refer to the documentation
- Join discussions in existing issues and pull requests

## Recognition

Contributors will be recognized in:
- Git commit history
- Release notes for significant contributions
- Package documentation where appropriate

Thank you for helping improve the Gleam Bitcoin library!