# Vuerama 2:1 Panorama Demo Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a minimal visionOS app that imports a stitched 2:1 panoramic photo, renders it on the inside of a sphere in a full immersive space, and supports both natural head viewing and pinch-drag orientation adjustment.

**Architecture:** Keep image validation and viewing-offset math in a platform-neutral Swift package with unit tests. The visionOS app uses SwiftUI for file import and controls, ImageIO for lightweight pixel metadata, and RealityKit for an unlit inward-facing sphere. The system supplies head tracking automatically through `ImmersiveSpace`; a SwiftUI drag gesture maps gaze-and-pinch input to yaw and pitch offsets.

**Tech Stack:** Swift 5.9+, SwiftUI, RealityKit, ImageIO, UniformTypeIdentifiers, Swift Package Manager, XCTest, Xcode visionOS app target.

---

## Task 1: Test the core panorama rules

**Files:**

- Create: `Package.swift`
- Create: `Sources/VueramaCore/Module.swift`
- Create: `Tests/VueramaCoreTests/PanoramaImageValidatorTests.swift`
- Create: `Tests/VueramaCoreTests/ViewingOffsetTests.swift`

**Steps:**

1. Add behavior tests for exact and near-2:1 images, invalid dimensions, and invalid aspect ratios.
2. Add behavior tests for yaw accumulation/wrapping, pitch clamping, and reset.
3. Run `swift test` and confirm failure because the production types do not exist.

## Task 2: Implement the tested core

**Files:**

- Create: `Sources/VueramaCore/PanoramaImageValidator.swift`
- Create: `Sources/VueramaCore/ViewingOffset.swift`

**Steps:**

1. Implement dimension and aspect-ratio validation.
2. Implement drag-to-yaw/pitch mapping, yaw normalization, pitch clamping, and reset.
3. Run `swift test` and confirm all tests pass.

## Task 3: Create the visionOS app shell

**Files:**

- Create: `Vuerama.xcodeproj/project.pbxproj`
- Create: `Vuerama/VueramaApp.swift`
- Create: `Vuerama/AppModel.swift`
- Create: `Vuerama/ContentView.swift`
- Create: `Vuerama/PanoramaImageMetadataReader.swift`

**Steps:**

1. Define a window and a full `ImmersiveSpace`.
2. Add a minimal file-picker UI accepting system image types.
3. Read dimensions with ImageIO, validate 2:1, and copy the selected file into the app cache while the security-scoped URL is open.
4. Enable immersive entry only after a valid panorama has been imported.

## Task 4: Render and control the panorama

**Files:**

- Create: `Vuerama/ImmersiveView.swift`

**Steps:**

1. Load the selected image as a RealityKit texture.
2. Apply it to an unlit sphere with reversed scale so the texture is visible from inside.
3. Keep the sphere centered at the immersive origin so system head tracking provides natural look-around behavior.
4. Map gaze-and-pinch drag translation to yaw/pitch rotation while preserving the final offset.
5. Add minimal reset and exit controls plus loading/error status.

## Task 5: Document and verify

**Files:**

- Modify: `README.md`
- Create: `.gitignore`

**Steps:**

1. Document current demo scope, supported files, permissions, test steps, and Vision Pro run steps.
2. Run `swift test` from a clean build state.
3. Run an unsigned visionOS simulator build with `xcodebuild` when the full Xcode developer directory is available.
4. Review `git diff`, commit intentionally, and push the demo to the configured private GitHub repository.
