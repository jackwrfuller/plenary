package main

import (
	"database/sql"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"fmt"

	"github.com/caarlos0/env/v11"
	_ "github.com/go-sql-driver/mysql"
	"mealplenary.jackwrfuller.au/internal/models"
)

type appConfig struct {
	Port string      `env:"APP_PORT" envDefault:"9999"`
	StaticDir string `env:"APP_STATIC_DIR" envDefault:"./ui/static"`

	DBUser string `env:"DB_USER" envDefault:"lagoon"`
	DBPass string `env:"DB_PASS" envDefault:"lagoon"`
	DBHost string `env:"DB_HOST" envDefault:"db"`
	DBPort string `env:"DB_PORT" envDefault:"3306"`
	DBName string `env:"DB_NAME" envDefault:"lagoon"`
}

type app struct {
	logger *slog.Logger
	cfg appConfig
	db     *sql.DB
	queries *models.Queries
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

	db, err := openDB(cfg.mysqlDSN())
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
	defer db.Close()

	queries := models.New(db)

	app := &app{
		logger: logger,
		cfg: cfg,
		db: db,
		queries: queries,
	}
	
	logger.Info("starting server", slog.String("port", app.cfg.Port))
	err = http.ListenAndServe(":" + app.cfg.Port, app.routes())

	logger.Error(err.Error())
	os.Exit(1)
}

func openDB(dsn string) (*sql.DB, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		db.Close()
		return nil, err
	}

	return db, nil
}

func (cfg appConfig) mysqlDSN() string {
	return fmt.Sprintf(
		"%s:%s@tcp(%s:%s)/%s?parseTime=true&charset=utf8mb4",
		cfg.DBUser,
		cfg.DBPass,
		cfg.DBHost,
		cfg.DBPort,
		cfg.DBName,
	)
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

