package main

import (
	"log/slog"
	"net/http"
	"path/filepath"
	"os"

	"github.com/caarlos0/env/v11"
)

type appConfig struct {
	Port string      `env:"APP_PORT" envDefault:"9999"`
	StaticDir string `env:"APP_STATIC_DIR" envDefault:"./ui/static"`
}

type app struct {
	logger *slog.Logger
	cfg appConfig
}

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		AddSource: false,
	}))

	var cfg appConfig
	err := env.Parse(&cfg)
	if err != nil {
		logger.Error(err.Error())
	}

	app := &app{
		logger: logger,
		cfg: cfg,
	}
	
	logger.Info("starting server", slog.String("port", app.cfg.Port))
	err = http.ListenAndServe(":" + app.cfg.Port, app.routes())

	logger.Error(err.Error())
	os.Exit(1)
}

// Custom file system used to ensure the "/static" directory from being listed
type neuteredFileSystem struct {
	fs http.FileSystem
}

func (nfs neuteredFileSystem) Open(path string) (http.File, error) {
	f, err := nfs.fs.Open(path)
	if err != nil {
		return nil, err
	}

	s, err := f.Stat()
	if err != nil {
		return nil, err
	}

	if s.IsDir() {
		index := filepath.Join(path, "index.html")
		if _, err := nfs.fs.Open(index); err != nil {
			closeErr := f.Close()
			if closeErr != nil {
				return nil, closeErr
			}

			return nil, err
		}
	}

	return f, nil
}

