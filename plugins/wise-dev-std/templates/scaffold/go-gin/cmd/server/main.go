// {{PROJECT_NAME}} — gin entrypoint (정적 템플릿 / static scaffold)
package main

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok", "env": env("ENV", "local")})
	})
	_ = r.Run(":8080")
}

func env(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
