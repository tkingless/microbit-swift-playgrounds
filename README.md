# microbit-swift-playgrounds

Assets.car and LiveView.storyboard need to be built:

mkdir build
 - ibtool --compile LiveView.storyboardc LiveView.storyboard
 - xcrun actool Assets.xcassets/ --compile build --platform iphoneos --minimum-deployment-target 8.0
