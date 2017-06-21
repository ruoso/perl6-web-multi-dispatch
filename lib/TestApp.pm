use FazApp;
class TestApp is FazApp {
    # the controllers are modules that export candidates into the multi dispatch
    our proto dispatch(|) {*}
    use TestApp::Controller::Root;
    use TestApp::Controller::Foo;

    multi method generate_dispatcher() {
        return self.generate_dispatcher(&dispatch);
    }
}
