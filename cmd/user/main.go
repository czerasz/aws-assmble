package main

import (
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/willdonnelly/passwd"
	"gopkg.in/yaml.v2"
)

type Config struct {
	Users []User `yaml:"users"`
}

func (c *Config) Load(path string) error {
	// open file
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()

	// read all content
	data, _ := ioutil.ReadAll(f)

	// unmarshal YAML
	if err := yaml.Unmarshal(data, c); err != nil {
		return err
	}

	return nil
}

type State string

const (
	Present State = "present"
	Absent  State = "absent"
)

type User struct {
	State      State    `yaml:"state"`
	UID        string   `yaml:"uid"`
	Name       string   `yaml:"name"`
	Comment    string   `yaml:"comment"`
	CreateHome bool     `yaml:"create_home"`
	HomeDir    string   `yaml:"home"`
	Shell      string   `yaml:"shell"`
	Group      string   `yaml:"group"`
	Groups     []string `yaml:"groups"`
	NonUnique  bool     `yaml:"non_unique"`
}

func main() {
	config := Config{}

	// get existing users
	users, err := passwd.Parse()
	if err != nil {
		log.Fatalf("could not get existing users: %s", err)
	}

	for _, u := range config.Users {
		// by default create the user
		create := true
		if u.State == Absent {
			create = false
		}

		if strings.TrimSpace(u.Name) == "" {
			log.Fatalf("user name is required")
		}

		if _, ok := users[u.Name]; ok {
			log.Printf("user '%s' already exists", u.Name)
			if create {
				continue
			}
		}

		if !create {
			err = deleteUser(u)
			if err != nil {
				log.Fatalf("failed to delete user '%s': %s", u.Name, err)
			}
			continue
		}

		err = createUser(u)
		if err != nil {
			log.Fatalf("failed to create user '%s': %s", u.Name, err)
		}
		log.Printf("user '%s' with UID %s created successfully", u.Name, u.UID)
	}

}

func deleteUser(u User) error {
	args := []string{}

	cmd := exec.Command("userdel",
		args...,
	)

	err := cmd.Run()
	if err != nil {
		return err
	}

	return nil
}

func createUser(u User) error {
	args := []string{}

	if u.UID != "" {
		args = append(args, "-u", u.UID)
	}

	if u.NonUnique {
		args = append(args, "-o")
	}

	if u.Group != "" {
		args = append(args, "-g", u.Group)
	}

	if len(u.Groups) > 0 {
		args = append(args, "-G", strings.Join(u.Groups, ","))
	}

	if u.Comment != "" {
		args = append(args, "-c", u.Comment)
	}

	if u.Shell != "" {
		args = append(args, "-s", u.Shell)
	}

	if u.HomeDir != "" {
		args = append(args, "-d", u.HomeDir)
	}

	if u.CreateHome {
		args = append(args, "-m")
	} else {
		args = append(args, "-M")
	}

	args = append(args, u.Name)

	cmd := exec.Command("useradd", args...)

	err := cmd.Run()
	if err != nil {
		return err
	}

	return nil
}
