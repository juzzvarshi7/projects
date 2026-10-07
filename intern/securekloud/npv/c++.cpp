#include <iostream>
#include <cmath>

class Point {
private:
  double x;
  double y;
  
public:
  // Constructor
  Point(double xCoord = 0.0, double yCoord = 0.0) : x(xCoord), y(yCoord) {}
  
  // Member functions
  void setValue(double xCoord, double yCoord) {
    x = xCoord;
    y = yCoord;
  }
  
  void showValue() const {
    std::cout << "Point: (" << x << ", " << y << ")\n";
  }
  
  double distanceTo(const Point& other) const {
    double deltaX = x - other.x;
    double deltaY = y - other.y;
    return std::sqrt(deltaX * deltaX + deltaY * deltaY);
  }
  
  bool isEqual(const Point& other) const {
    return (x == other.x) && (y == other.y);
  }
};

int main() {
  // Example usage
  Point point1(2.0, 3.0);
  Point point2(4.0, 1.0);
  
  // Set and show values
  point1.showValue();
  point2.showValue();
  
  // Find distance between two points
  double distance = point1.distanceTo(point2);
  std::cout << "Distance between points: " << distance << std::endl;
  
  // Check if two points are equal
  if (point1.isEqual(point2)) {
    std::cout << "Points are equal.\n";
  } else {
    std::cout << "Points are not equal.\n";
  }
  
  return 0;
}
