function out = coerceVector(vector, min, max)

vector(vector < min) = min;
vector(vector > max) = max; 
out = vector; 

end
