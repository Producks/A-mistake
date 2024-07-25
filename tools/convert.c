/*
    Convert Text input to mario 2 custom ascii file
    Producks 2024-07-20
*/

#include <unistd.h>
#include <stdio.h>
#include <string.h>

const static char magic_table[] = { 
    0x00, // Padding
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00, 
    0x7C, // Space 
    0x40, // !
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, 
    0x02, // 0
    0x03, // 1
    0x04, // 2
    0x05, // 3
    0x06, // 4
    0x07, // 5
    0x08, // 6
    0x09, // 7
    0x0A, // 8
    0x0B, // 9
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x41, // ?
    0x00,
    0x0C, // A
    0x0D, // B
    0x0E, // C
    0x0F, // D
    0x10, // E
    0x11, // F
    0x12, // G
    0x13, // H
    0x14, // I
    0x15, // J
    0x16, // K
    0x17, // L missed the L RIP
    0x18, // M
    0x19, // N
    0x1A, // O
    0x1B, // P
    0x1C, // Q
    0x1D, // R
    0x1E, // S
    0x1F, // T
    0x20, // U
    0x21, // V
    0x22, // W
    0x23, // X
    0x24, // Y
    0x25, // Z
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, 
    0x26, // a
    0x27, // b
    0x28, // c
    0x29, // d
    0x2A, // e
    0x2B, // f
    0x2C, // g
    0x2D, // h
    0x2E, // i
    0x2F, // j
    0x30, // k
    0x31, // l
    0x32, // m
    0x33, // n
    0x34, // o
    0x35, // p
    0x36, // q
    0x37, // r
    0x38, // s
    0x39, // t
    0x3A, // u
    0x3B, // v
    0x3C, // w
    0x3D, // x
    0x3E, // y
    0x3F, // z
};

int main(int argc, char **argv)
{
    if (argc != 2){
        printf("No argument were provided\n");
        return 1;
    }
    FILE *file_stream = fopen("result.txt", "w");
    if (file_stream == NULL){
        perror("fopen");
        return 1;
    }
    fprintf(file_stream, "\t.db $XX, $XX, $%02lX\n\t.db", strlen(argv[1])); // Space for Adress location and the length get auto added
    for (int index = 0; argv[1][index]; index++){
        fprintf(file_stream, " $%02X", magic_table[argv[1][index]]);
        if (argv[1][index + 1] != '\0')
            fprintf(file_stream, ",");
    }
    fprintf(file_stream, "\n\t.db $00");
    fclose(file_stream);
    return 0;
}
