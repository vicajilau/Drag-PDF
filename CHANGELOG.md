## 4.1.0
### Features & UI
* Implemented adaptive layout architecture with platform-specific components and refactored the file management UI.
* Enabled tap-to-open functionality for non-desktop (mobile) platforms in the file selector card.
* Modernized the application theme and updated the localization accessor pattern.
* Updated application icons.
* Hidden the floating action button when output files already exist.

### Performance & Architecture
* Refactored `PdfCombinerViewModel` into a `ChangeNotifier` to enable more efficient reactive UI updates.

### Fixes
* Fixed desktop layout check to properly exclude mobile platforms on large viewport sizes.

### Build & Dependencies
* Updated key dependencies (including `cunning_document_scanner` to `2.3.0`, `file_picker` to `11.0.1`, and `pdf_combiner` to `6.1.0`).
* Upgraded Gradle, Android Gradle Plugin, NDK version, and aligned Kotlin to version `2.2.21`.
* Updated iOS deployment target, configured scene manifest, and refreshed project build settings.
* Removed redundant CocoaPods configuration for Darwin platforms in favor of modern setup.

## 4.0.2
### General
* Update dependencies

## 4.0.0
### General
* Fixed an issue where app was not going back properly. [#1](https://github.com/vicajilau/Drag-PDF/pull/1)
* Added license.
* Removed Firebase.
* Added Privacy.
* Simplified flows.