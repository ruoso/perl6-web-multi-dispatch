use HTTP::Request;
use HTTP::Response;
use URI;

class FazApp::RequestContext {
    has HTTP::Request $.req;
    has HTTP::Response $.res;
}

class FazApp {
    has Int $.port;
    has Bool $.is_https;

    method generate_context(HTTP::Request $req, HTTP::Response $res) {
        return FazApp::RequestContext.new(:$req, :$res);
    }
    
    multi method generate_dispatcher(Callable $dispatch) {
        my $closed_over_self = self;
        return sub handle_request(HTTP::Request $req, HTTP::Response $res) {
            my $*app = $closed_over_self;
            my $*c = $*app.generate_context($req, $res);
            my URI $uri .= new($req.uri);
            my @parts = grep { $_ ne "" }, split /\//, $uri.path;
            $dispatch(|@parts, $req);
            CATCH {
                when X::Multi::NoMatch {
                    $res.status = 404;
                    $res.close($uri.path ~ " Not found ");
                }
                default {
                    $res.status = 500;
                    $res.close($uri.path ~ " Error: " ~ .gist);
                }
            }
        }
    }
}   
    

