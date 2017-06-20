unit module TestApp::Types;
use HTTP::Request;
use HTTP::Response;

subset StrToInt of Str where +*;
subset GET of HTTP::Request where { .method eq 'GET' };
