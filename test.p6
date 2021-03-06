use Test;

use lib 'lib';
use HTTP::Request;
use HTTP::Response;
use TestApp;

my $app = TestApp.new();
my $handle_request = $app.generate_dispatcher();

my @tests = (
             ['GET', '/foo/1/bar/2', 200],
             ['GET', '/foo/lalala/bar/2', 404],
             ['GET', '/foo/1', 200],
             ['GET', '/', 200],
             ['GET', '/foo', 404],
             ['POST', '/foo/1/bar/2', 405],
             ['POST', '/foo/lalala/bar/2', 404],
             ['POST', '/foo/1', 200],
             ['POST', '/', 200],
             ['POST', '/foo', 404],
            );

plan @tests.elems;

for @tests -> $test {
  my $method = $test[0];
  my $path = $test[1];
  my $res = HTTP::Response.new();
  my $req = HTTP::Request.new(:method($method), :uri($path));
  $handle_request($req, $res);
  is $res.status, $test[2], "$method $path";
}
