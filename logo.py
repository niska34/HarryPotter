import os
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
from scipy.ndimage import gaussian_gradient_magnitude
from wordcloud import WordCloud, ImageColorGenerator

# get data directory
d = os.path.dirname(__file__) if "__file__" in locals() else os.getcwd()

# load text
text = open(
    os.path.join(d, "ProcessedMovieData - Scripts, Characters/Dialogue_allMovies.csv"),
    encoding="utf-8",
).read()

# load image
logo_color = np.array(Image.open(os.path.join(d, "hollows.png")))
logo_color = logo_color[::3, ::3]  # subsample by factor of 3

# ensure image is in RGBA format for transparency handling
if logo_color.shape[-1] == 3:  # no alpha channel
    logo_color = np.concatenate(
        [logo_color, 255 * np.ones((*logo_color.shape[:2], 1), dtype=np.uint8)], axis=-1
    )

# create a mask (True where it should be transparent)
logo_mask = np.all(
    logo_color[:, :, :3] != 255, axis=-1
)  # assuming white is the color to mask out

# create wordcloud with transparent background
wc = WordCloud(
    background_color=None,
    mode="RGBA",
    max_words=200,
    mask=logo_mask,
    max_font_size=40,
    random_state=42,
    relative_scaling=0,
)

# generate word cloud
wc.generate(text)

# create coloring from image
image_colors = ImageColorGenerator(logo_color)
wc.recolor(color_func=image_colors)

# save to file with transparency
wc.to_file("hollowslogo.png")

# display the generated image
plt.figure(figsize=(10, 10))
plt.imshow(wc, interpolation="bilinear")
plt.axis("off")  # turn off axis
plt.show()
