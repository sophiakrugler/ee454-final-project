import struct
import numpy as np

def read_mnist_image(file_path, image_index=0):
    """
    Reads an image from an MNIST image file at the specified index.
    :param file_path: Path to the MNIST image file.
    :param image_index: Index of the image to read (0-based).
    :return: The specified image as a numpy array.
    """
    with open(file_path, 'rb') as f:
        # Read header: magic number, number of images, rows, and columns
        magic, num_images, rows, cols = struct.unpack('>IIII', f.read(16))
        if magic != 2051:
            raise ValueError(f"Invalid magic number {magic} in image file")
        if image_index >= num_images:
            raise IndexError(f"Image index {image_index} out of range (max {num_images-1})")
        
        # Skip to the desired image
        f.seek(image_index * rows * cols, 1)  # Skip image_index images
        image = np.frombuffer(f.read(rows * cols), dtype=np.uint8).reshape(rows, cols)
        return image

def read_mnist_label(file_path, label_index=0):
    """
    Reads a label from an MNIST label file at the specified index.
    :param file_path: Path to the MNIST label file.
    :param label_index: Index of the label to read (0-based).
    :return: The specified label as an integer.
    """
    with open(file_path, 'rb') as f:
        # Read header: magic number, number of labels
        magic, num_labels = struct.unpack('>II', f.read(8))
        if magic != 2049:
            raise ValueError(f"Invalid magic number {magic} in label file")
        if label_index >= num_labels:
            raise IndexError(f"Label index {label_index} out of range (max {num_labels-1})")
        
        # Skip to the desired label
        f.seek(label_index, 1)  # Skip label_index labels
        label = struct.unpack('>B', f.read(1))[0]
        return label

def save_binary_to_hex_file(binary_data, hex_file_path):
    """Saves binary data to a .hex file in hexadecimal format."""
    with open(hex_file_path, 'w') as hex_file:
        for byte in binary_data:
            hex_file.write(f"{byte:02x}\n")  # Write each byte in hex format (2 digits)
    print(f"Hex data saved to {hex_file_path}")

# Paths to the MNIST dataset files
image_file_path = "MNIST_ORG/t10k-images.idx3-ubyte"
label_file_path = "MNIST_ORG/t10k-labels.idx1-ubyte"

# Read the second image and label (index 1, since it's 0-based)
image_index = 1
second_image = read_mnist_image(image_file_path, image_index=image_index)
second_label = read_mnist_label(label_file_path, label_index=image_index)

# Convert image to binary and save to a hex file
image_binary = second_image.tobytes()
image_hex_file_path = "../second_image.hex"
save_binary_to_hex_file(image_binary, image_hex_file_path)

# Save label to a separate hex file
label_hex_file_path = "../second_label.hex"
label_binary = struct.pack('B', second_label)  # Pack label as a single byte
save_binary_to_hex_file(label_binary, label_hex_file_path)

print(f"Second label: {second_label}")
print(f"Second image binary length: {len(image_binary)} bytes")
