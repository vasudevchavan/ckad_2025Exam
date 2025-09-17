import tornado.ioloop
import tornado.web


class MainHandler(tornado.web.RequestHandler):
    def get(self):
        title = "Hello Blue GKE!"
        bgcolor = "blue"
        self.render("template.html",title=title,bgcolor=bgcolor)
        print(self.request)

""" class GreenHandler(tornado.web.RequestHandler):
    def get(self):
        title = "Hello Green GKE!"
        bgcolor = "green"
        self.render("template.html",title=title,bgcolor=bgcolor)
        print(self.request) """

""" class RedHandler(tornado.web.RequestHandler):
    def get(self):
        title = "Hello Red GKE!"
        bgcolor = "red"
        self.render("template.html",title=title,bgcolor=bgcolor)
        print(self.request) """


""" class NationHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("india.html") """


 
def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
      """   (r"/green", GreenHandler),
        (r"/red", RedHandler),
        (r"/nation", NationHandler) """
    ])



if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
