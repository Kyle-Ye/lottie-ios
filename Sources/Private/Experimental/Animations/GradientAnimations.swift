// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAGradientLayer {
  /// Adds gradient-related animations to this layer, from the given `GradientFill`
  func addAnimations(for gradientFill: GradientFill, context: LayerAnimationContext) {
    switch gradientFill.gradientType {
    case .linear:
      type = .axial
    case .radial:
      type = .radial
    case .none:
      break
    }

    // We have to set `colors` to a non-nil value with some valid number of colors
    // for the color animation below to have any effect (not sure why)
    colors = .init(
      repeating: CGColor.rgb(0, 0, 0),
      count: gradientFill.numberOfColors)

    addAnimation(
      for: .colors,
      keyframes: gradientFill.colors.keyframes,
      value: { colorComponents in
        gradientFill.colorConfiguration(from: colorComponents).map { $0.color }
      },
      context: context)

    addAnimation(
      for: .locations,
      keyframes: gradientFill.colors.keyframes,
      value: { colorComponents in
        gradientFill.colorConfiguration(from: colorComponents).map { $0.location }
      },
      context: context)

    addAnimation(
      for: .startPoint,
      keyframes: gradientFill.startPoint.keyframes,
      value: { absoluteStartPoint in
        // Lottie animation files express `startPoint` as an absolute point value,
        // so we have to divide by the width/height of this layer to get the
        // relative decimal values expected by Core Animation.
        percentBasedPoint(from: absoluteStartPoint)
      },
      context: context)

    // The new gradient seems slightly longer than the old one,
    // are my points being put in the wrong place?
    let startPoint = gradientFill.startPoint.keyframes.first!.value.pointValue
    let startPointShape = CAShapeLayer()
    startPointShape.fillColor = .rgb(1, 0, 0)
    startPointShape.path = CGPath(ellipseIn: CGRect(center: startPoint, size: .init(width: 40, height: 40)), transform: nil)
    addSublayer(startPointShape)

    let endPoint = gradientFill.endPoint.keyframes.first!.value.pointValue
    let endPointShape = CAShapeLayer()
    endPointShape.fillColor = .rgb(0, 0, 1)
    endPointShape.path = CGPath(ellipseIn: CGRect(center: endPoint, size: .init(width: 40, height: 40)), transform: nil)
    addSublayer(endPointShape)

    addAnimation(
      for: .endPoint,
      keyframes: gradientFill.endPoint.keyframes,
      value: { absoluteEndPoint in
        // Lottie animation files express `endPoint` as an absolute point value,
        // so we have to divide by the width/height of this layer to get the
        // relative decimal values expected by Core Animation.
        percentBasedPoint(from: absoluteEndPoint)
      },
      context: context)
  }
}

extension GradientFill {
  /// Converts this [Double] to [CGColor] by combining each group of four values into a single CGColor
  fileprivate func colorConfiguration(from colorComponents: [Double]) -> [(color: CGColor, location: CGFloat)] {
    precondition(
      colorComponents.count >= numberOfColors * 4,
      "Each color must have RGB components and a location component")

    var cgColors = [(color: CGColor, location: CGFloat)]()

    for colorIndex in 0..<numberOfColors {
      let colorStartIndex = colorIndex * 4

      let location = colorComponents[colorStartIndex]

      let color = CGColor.rgb(
        colorComponents[colorStartIndex + 1],
        colorComponents[colorStartIndex + 2],
        colorComponents[colorStartIndex + 3])

      cgColors.append((color, location))
    }

    return cgColors
  }
}
