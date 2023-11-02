#include <stdio.h>
#define WIDTH 160
#define HEIGHT 120

void setPixel(char* screen, int x, int y) {
    screen[y*(WIDTH + 1) + x] = '#';
}

void circle(char* screen, int centre_x, int centre_y, int radius) {
    int offset_y = 0;
    int offset_x = radius;
    int crit = 1 - radius;
    while (offset_y <= offset_x) {
        setPixel(screen, centre_x + offset_x, centre_y + offset_y);// -- octant 1
        setPixel(screen, centre_x + offset_y, centre_y + offset_x);// -- octant 2
        setPixel(screen, centre_x - offset_x, centre_y + offset_y);// -- octant 4
        setPixel(screen, centre_x - offset_y, centre_y + offset_x);// -- octant 3
        setPixel(screen, centre_x - offset_x, centre_y - offset_y);// -- octant 5
        setPixel(screen, centre_x - offset_y, centre_y - offset_x);// -- octant 6
        setPixel(screen, centre_x + offset_x, centre_y - offset_y);// -- octant 8
        setPixel(screen, centre_x + offset_y, centre_y - offset_x);// -- octant 7
        offset_y = offset_y + 1;
        if (crit <= 0) {
            crit = crit + 2 * offset_y + 1;
        } else {
            offset_x = offset_x - 1;
            crit = crit + 2 * (offset_y - offset_x) + 1;
        }
    }
}

void clr_screen(char* screen) {
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            screen[y*(WIDTH + 1) + x] = ' ';
        }
        screen[(y + 1)*(WIDTH + 1) - 1] = '\n';
    }
    screen[WIDTH*HEIGHT + HEIGHT] = '\0';
}


int main()
{
    char screen[WIDTH*HEIGHT + HEIGHT + 1];
    clr_screen(screen);
    circle(screen, 80, 60, 30);
    circle(screen, 80, 60, 28);
    circle(screen, 80, 60, 24);
    circle(screen, 80, 60, 20);
    circle(screen, 80, 60, 18);
    circle(screen, 80, 60, 14);
    printf("%s", screen);

    return 0;
}