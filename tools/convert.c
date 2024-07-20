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
    0x5C, // Space 
    0x3E, // !
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
    0x34, // 0
    0x35, // 1
    0x36, // 2
    0x37, // 3
    0x38, // 4
    0x39, // 5
    0x3A, // 6
    0x3B, // 7
    0x3C, // 8
    0x3D, // 9
    0x00,
    0x00,
    0x00,
    0x00, 
    0x00, 
    0x3F, // ?
    0x00,
    0x00, // A
    0x01, // B
    0x02, // C
    0x03, // D
    0x04, // E
    0x05, // F
    0x06, // G
    0x07, // H
    0x08, // I
    0x09, // J
    0x0A, // K
    0x24, // L missed the L RIP
    0x0B, // M
    0x0C, // N
    0x0D, // O
    0x0E, // P
    0x0F, // Q
    0x10, // R
    0x11, // S
    0x12, // T
    0x13, // U
    0x14, // V
    0x15, // W
    0x16, // X
    0x17, // Y
    0x18, // Z
    0x00, 
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, 
    0x19, // a
    0x1A, // b
    0x1B, // c
    0x1C, // d
    0x1D, // e
    0x1E, // f
    0x1F, // g
    0x20, // h
    0x21, // i
    0x22, // j
    0x23, // k
    0x24, // l
    0x25, // m
    0x26, // n
    0x27, // o
    0x28, // p
    0x29, // q
    0x2A, // r
    0x2B, // s
    0x2C, // t
    0x2D, // u
    0x2E, // v
    0x2F, // w
    0x30, // x
    0x31, // y
    0x32, // z
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
