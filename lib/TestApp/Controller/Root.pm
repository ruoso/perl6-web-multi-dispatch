unit module TestApp::Controller::Root;
    
use HTTP::Request;
use HTTP::Response;

multi dispatch( HTTP::Request $req ) is export {
  $*c.res.status = 200;
  $*c.res.close("Final request in the chain on the root context");
}
