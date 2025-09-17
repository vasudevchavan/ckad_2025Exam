package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
)

// getBackgroundColor retrieves the color from env or defaults to white.
func getBackgroundColor() string {
	source := os.Getenv("COLOR_SOURCE")

	switch source {
	case "env":
		color := os.Getenv("BACKGROUND_COLOR")
		if color != "" {
			return color
		}
		log.Printf("COLOR_SOURCE=env but BACKGROUND_COLOR is not set, falling back to default")
	case "file":
		data, err := os.ReadFile("/app/color.txt")
		if err != nil {
			log.Printf("COLOR_SOURCE=file but failed to read color.txt: %v", err)
		} else {
			color := strings.TrimSpace(string(data))
			if color != "" {
				return color
			}
		}
	default:
		log.Printf("Invalid or unset COLOR_SOURCE: %q. Using default color", source)
	}

	// fallback default
	return "#FFFFFF"
}

// handler for the homepage
func homeHandler(w http.ResponseWriter, r *http.Request) {
	bgColor := getBackgroundColor()

	html := fmt.Sprintf(`
		<!DOCTYPE html>
		<html>
		<head>
			<title>Go Web App</title>
			<style>
				body {
					background-color: %s;
					color: #333;
					font-family: sans-serif;
					text-align: center;
					padding-top: 50px;
				}
			</style>
		</head>
		<body>
			<h1>Hello from Go!</h1>
			<p>The background color is set to <strong>%s</strong></p>
		</body>
		</html>
	`, bgColor, bgColor)

	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(html))
}

func main() {
	http.HandleFunc("/", homeHandler)

	port := ":8080"
	log.Printf("Starting server on http://localhost%s ...", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed: %s", err)
	}
}
