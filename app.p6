use lib 'lib';
use HTTP::Server::Async;
use TestApp;

my TestApp $app .= new();
my HTTP::Server::Async $s .= new(:port(8080));
$s.handler($app.generate_dispatcher());

$s.listen(True);
