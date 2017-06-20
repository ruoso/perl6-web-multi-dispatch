use HTTP::Request;
use HTTP::Response;

multi dispatch( HTTP::Request $req, HTTP::Response $res ) is export {
  $res.status = 200;
  $res.message = "Final request in the chain on the root context";
}
