#include <iostream>

int main() {

    const double PI = 3.14159; //conts makes a variable that cant be modify
    double radius = 10;
    double circumference = 2 * PI * radius;

    std::cout<<circumference<<" centimeters";
    return 0;
}