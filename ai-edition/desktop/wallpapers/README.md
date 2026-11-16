# KushOS wallpapers | خلفيات KushOS

Four desktop wallpapers inspired by the Kingdom of Kush and the
Sudanese landscape — أربع خلفيات مستوحاة من حضارة كوش والبيئة السودانية:

| File | Theme |
| --- | --- |
| `meroe-pyramids` | Pyramids of Meroe at sunset — أهرامات مروي وقت الغروب |
| `nile-sunset` | The Nile at sunset with a felucca — النيل وقت الغروب والفلوكة |
| `nubian-village` | Colourful Nubian houses — بيوت نوبية ملوّنة |
| `kush-temple` | A Kushite temple under the stars — معبد كوشي تحت النجوم |

## Change the wallpaper | تغيير الخلفية

```sh
wallpaper list            # show all wallpapers
wallpaper meroe-pyramids  # pick one
wallpaper next            # cycle to the next one
```

The default is `meroe-pyramids`. The current wallpaper is a symlink
at `/usr/share/kushos/wallpaper.png` pointing at the chosen file in
`/usr/share/kushos/wallpapers/`.

## Files here

The `.svg` files in this folder are the editable vector sources of
each wallpaper (open them in Inkscape or any vector editor). The
ready-made image ships rendered 1280×800 PNGs of the same four
themes — render the SVGs with any SVG tool (for example
`rsvg-convert` or Inkscape) to replace them, or drop your own PNG/JPG
into `/usr/share/kushos/wallpapers/` and run `wallpaper <name>`.
