import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/screensaver/screensaver.mjs" as Saver

// screensaver.mjs with plain numbers. Run one function at a time by screensaver.bats.
TestCase {
  name: "screensaver"

  function test_image_index() {
    compare(Saver.imageIndex(0, 0, 1, 0), -1)
    compare(Saver.imageIndex(0, 0, 1, 3), 0)
    compare(Saver.imageIndex(4, 0, 1, 3), 1)
    // Two outputs, five images: never the same image on both at one step.
    for (let step = 0; step < 10; step++)
      verify(Saver.imageIndex(step, 0, 2, 5) !== Saver.imageIndex(step, 1, 2, 5))
    // One image, two outputs: both show it.
    compare(Saver.imageIndex(3, 1, 2, 1), 0)
  }

  function test_clock_spot() {
    for (let step = 0; step < 50; step++) {
      const spot = Saver.clockSpot(step, 0)
      verify(spot.x >= 0 && spot.x < 1 && spot.y >= 0 && spot.y < 1)
      const next = Saver.clockSpot(step + 1, 0)
      verify(Math.abs(next.x - spot.x) + Math.abs(next.y - spot.y) > 0.1)
    }
    verify(Saver.clockSpot(0, 1).x !== Saver.clockSpot(0, 0).x)
  }
}
