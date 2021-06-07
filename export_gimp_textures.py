def main(xcf_path, dds_path):
    from gimpfu import pdb
    import platform
    import sys

    pdb.gimp_message("Started exporting textures.")
    pdb.gimp_message(platform.python_version())

    try:
        import os
        import pydoc

        dds_parent = os.path.dirname(dds_path)
        pdb.gimp_message(xcf_path + " -> " + dds_path)
        try:
            os.makedirs(dds_parent)
        except:
            pass
        image = pdb.gimp_xcf_load(1, xcf_path, xcf_path)
        #pdb.gimp_message(str(pdb.file_dds_save.params))
        pdb.file_dds_save(
            image, 
            # (13, 'image', 'Input image'), 
            pdb.gimp_image_merge_visible_layers(image, 1), 
            # (16, 'drawable', 'Drawable to save'), 
            dds_path, 
            # (4, 'filename', 'The name of the file to save the image as'),
            dds_path, 
            # (4, 'raw-filename', 'The name entered'),
            3, 
            # (0, 'compression-format', 'Compression format # (0 = None, 1 = BC1/DXT1, 2 = BC2/DXT3, 3 = BC3/DXT5, 4 = BC3n/DXT5nm, 5 = BC4/ATI1N, 6 = BC5/ATI2N, 7 = RXGB # (DXT5), 8 = Alpha Exponent # (DXT5), 9 = YCoCg # (DXT5), 10 = YCoCg scaled # (DXT5))'),
            1, 
            # (0, 'mipmaps', 'How to handle mipmaps # (0 = No mipmaps, 1 = Generate mipmaps, 2 = Use existing mipmaps # (layers)'),
            0, 
            # (0, 'savetype', 'How to save the image # (0 = selected layer, 1 = cube map, 2 = volume map, 3 = texture array'),
            0, 
            # (0, 'format', 'Custom pixel format # (0 = default, 1 = R5G6B5, 2 = RGBA4, 3 = RGB5A1, 4 = RGB10A2)'),
            -1, 
            # (0, 'transparent-index', 'Index of transparent color or -1 to disable # (for indexed images only).'),
            0,
            # (0, 'mipmap-filter', 'Filtering to use when generating mipmaps # (0 = default, 1 = nearest, 2 = box, 3 = triangle, 4 = quadratic, 5 = bspline, 6 = mitchell, 7 = lanczos, 8 = kaiser)'),
            0, 
            # (0, 'mipmap-wrap', 'Wrap mode to use when generating mipmaps # (0 = default, 1 = mirror, 2 = repeat, 3 = clamp)'),
            0,
            # (0, 'gamma-correct', 'Use gamma correct mipmap filtering'),
            0,
            # (0, 'srgb', 'Use sRGB colorspace for gamma correction'),
            2.2,
            # (3, 'gamma', 'Gamma value to use for gamma correction # (i.e. 2.2)'),
            1,
            # (0, 'perceptual-metric', 'Use a perceptual error metric during compression'),
            0,
            # (0, 'preserve-alpha-coverage', 'Preserve alpha test converage for alpha channel maps'),
            0
            # (3, 'alpha-test-threshold', 'Alpha test threshold value for which alpha test converage should be preserved')
        )
        pdb.gimp_image_delete(image)
    except:
        pdb.gimp_message("An unhandled error occurred: " + str(sys.exc_info()[0]) + ": " + str(sys.exc_info()[1]))

    pdb.gimp_quit(0)