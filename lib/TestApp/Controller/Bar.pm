unit module TestApp::Controller::Bar;
use HTTP::Request;
use HTTP::Response;
use TestApp::Types;
use TestApp::Context::Foo;
use TestApp::Context::Bar;

multi dispatch( TestApp::Context::Foo $c,
                'bar', Int(TestApp::Types::StrToInt) $bar_id,
                *@remaining ) is export {
  dispatch(TestApp::Context::Bar.new(:foocontext($c),
                                     :bar_id($bar_id)), |@remaining);
}

multi dispatch( TestApp::Context::Bar $c, TestApp::Types::GET $req ) is export {
  $*c.res.status = 200;
  $*c.res.close("Final action in the chain for foo " ~ $c.foocontext.foo_id ~
    " bar " ~ $c.bar_id);
}

multi dispatch( TestApp::Context::Bar $c, HTTP::Request $req ) is export {
  $*c.res.status = 405;
  $*c.res.close("method not allowed: foo " ~ $c.foocontext.foo_id ~
    " bar " ~ $c.bar_id);
}
