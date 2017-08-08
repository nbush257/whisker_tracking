import pims
import matplotlib.pyplot as plt
def getMask(image):
    rows, cols = image.shape
    plt.imshow(image, cmap='gray')
    plt.axis([0, cols, 0, rows])
    plt.gca().invert_yaxis()

    plt.title('Outline the Mask. Left to add, right to remove, middle to continue')
    plt.draw()
    plt.pause(0.001)
    pts = np.asarray(plt.ginput(-1, timeout=0, show_clicks=True))
    rr, cc = polygon(pts[:, 1], pts[:, 0], (rows, cols))
    return rr,cc

def applyMask(rr,cc,whiskers)
