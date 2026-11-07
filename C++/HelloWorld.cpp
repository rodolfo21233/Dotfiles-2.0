#include <iostream> //import to print to console
#include <vector> //for typedef

typedef std::string text_t;
typedef int numero_t;
using text2_t = std::string;
int main() {
    //Print
    std::cout<<"Hello World"<<"\n"; // print Hello world and move to next line
    std::cout<<":)"<<"\n";

    //variable
    int x; //variable for whole numbers
    x = 5; //sets variable to 5
    // You can set the variable in only 1 line example:
    int y = 5;
    double avarage = 10.99; // double = 15 decimals float = 7 decimals 

    //Char
    char letter = 'A';

    //Bool
    bool water = true;

    //String
    std::string name = "nombre";
    
    std::cout<<x + y<<"\n"; 
    std::cout<<avarage<<"\n"; 
    
    //Typedef and Type aliases
    text_t name2 = "nombre2";
    std::cout<<name2<<"\n";

    //conversions
    double r = (int)3.14; // adding (int) to double makes it int
    r = r + 1.5; 
    std::cout<<(char)52; //
    return 0;
}