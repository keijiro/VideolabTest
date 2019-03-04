VideolabTest
============

![gif](https://i.imgur.com/CNAe3Uk.gif)
![gif](https://i.imgur.com/2PNr9Vt.gif)

This repository contains several examples of [OP-Z] [videolab] visuals.

[OP-Z]: https://www.teenageengineering.com/products/op-z
[videolab]: https://github.com/teenageengineering/videolab

Version dependency
------------------

Currently this project is dependent on [videolab-1.1] that is compatible with
OP-Z v1.1 iOS app.

This repository doesn't include the videolab package. You have to manually
install `videolab-1.1.unitypackage` to open the examples on Unity Editor.

Note that you should use Unity 2018.2 when building videopaks; It's the only
version compatible with OP-Z v1.1.

[videolab-1.1]:
  https://github.com/teenageengineering/videolab/releases/tag/v1.1

Try without Unity
-----------------

You can try the videopaks without Unity.

#### Steps for iOS OP-Z app

1. Download one of the videopak zip files from [Releases].
2. Connect an iOS device to a computer and open it on iTunes.
3. Open File Sharing view and select OP-Z from Apps.
4. Drag and drop the extracted videopaks folder into OP-Z Documents.

![drag and drop](https://i.imgur.com/Rk5IvFq.png)

[Releases]: https://github.com/keijiro/VideolabTest/releases

#### Steps for macOS OP-Z app

1. Download one of the videopak zip files from [Releases].
2. Select OP-Z app in the Application folder, and then select "Show Package
   Contents" from the right click menu.
3. Navigate to Contents > Resources > Data > StreamingAssets > videopaks.
4. Extract and copy the contents of the videopak zip file into the
   videopaks folder.

License
-------

Obj files contained in `Assets/VideolabTest/Poly/Model` ([Kangaroo], [Koala],
[Rat], [Duck]) are created by Google and released under a [CC-BY] license.

[Kangaroo]: https://poly.google.com/view/3yiIERrKNQr
[Koala]: https://poly.google.com/view/9x4UY7n27nI
[Rat]: https://poly.google.com/view/9h_k4Jkm3Le
[Duck]: https://poly.google.com/view/frSLi6b6Vid
[CC-BY]: https://creativecommons.org/licenses/by/3.0/

A TiltBlush sketch used in "TiltBrush" scene was created by Lisa Padilla and
published under a [CC-BY] license. See the original Poly page "[Colorful Man]"
for further details.

[Colorful Man]: https://poly.google.com/view/2s0cpvWShgk

All other parts of this project are put under [CC0].

[CC0]: https://creativecommons.org/share-your-work/public-domain/cc0/
