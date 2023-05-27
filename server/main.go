package main

func main() {
	go Launch()
	go WebLaunch()
	select {}
}
