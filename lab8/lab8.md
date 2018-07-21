#LAB8 REPORT

1. PIPE

Pipe is in fact a redirect op. It redirects the predecessor's stdout to the successor's stdin.

A naive implementation is to store the predecessor's stdout to a temporary file and then feed it into the successor.

An improved method is to create a buffer in memory (with FIFO structures, maybe), fills the buffer with the predecessor's output and supply to the successor. Careful memory management required, though.

2. Hard link and soft link

For each file, we record a count for each hard link (and a mutex, maybe). All the hard links points to the same disk address, and when all the hard links are removed, the file is deleted.

As for soft link, the file itself only contains a path to the target it points to. When the soft link is opened, the os switch to the target file and opens its disk address.
