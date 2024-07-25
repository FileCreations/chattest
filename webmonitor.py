import requests
import time
import logging
import psutil
import threading
import socket
import subprocess
from colorama import init, Fore
from urllib.parse import urlparse

init(autoreset=True)

logging.basicConfig(level=logging.INFO, format='%(message)s')

CONN_STATUSES = {
    psutil.CONN_ESTABLISHED: "ESTABLISHED",
    psutil.CONN_SYN_SENT: "SYN_SENT",
    psutil.CONN_SYN_RECV: "SYN_RECV",
    psutil.CONN_FIN_WAIT1: "FIN_WAIT1",
    psutil.CONN_FIN_WAIT2: "FIN_WAIT2",
    psutil.CONN_TIME_WAIT: "TIME_WAIT",
    psutil.CONN_CLOSE: "CLOSE",
    psutil.CONN_CLOSE_WAIT: "CLOSE_WAIT",
    psutil.CONN_LAST_ACK: "LAST_ACK",
    psutil.CONN_LISTEN: "LISTEN",
    psutil.CONN_CLOSING: "CLOSING",
    psutil.CONN_NONE: "NONE"
}

def check_website(url):
    logging.info(Fore.YELLOW + "{=} Looking for website.")
    try:
        response = requests.get(url)
        if response.status_code == 200:
            logging.info(Fore.GREEN + "{+} Website found.")
            return True
        else:
            logging.info(Fore.RED + "{-} Website not found.")
            return False
    except requests.exceptions.RequestException:
        logging.info(Fore.RED + "{-} Website not found.")
        return False

def monitor_network(target_ips):
    logging.info(Fore.BLUE + "{*} Starting network traffic monitoring...")
    while True:
        connections = psutil.net_connections(kind='inet')
        for conn in connections:
            if conn.raddr:
                if conn.raddr.ip in target_ips or conn.laddr.ip in target_ips:
                    status = CONN_STATUSES.get(conn.status, "UNKNOWN")
                    description = get_connection_description(conn)
                    logging.info(Fore.BLUE + f"Network traffic: {conn.laddr.ip}:{conn.laddr.port} -> {conn.raddr.ip}:{conn.raddr.port} (Status: {status}) - {description}")
        time.sleep(5)

def get_connection_description(conn):
    if conn.status == psutil.CONN_ESTABLISHED:
        return "Data transfer in progress."
    elif conn.status == psutil.CONN_SYN_SENT:
        return "Attempting to establish a connection (sending)."
    elif conn.status == psutil.CONN_SYN_RECV:
        return "Attempting to establish a connection (receiving)."
    elif conn.status == psutil.CONN_FIN_WAIT1 or conn.status == psutil.CONN_FIN_WAIT2:
        return "Connection is closing (waiting for final acknowledgment)."
    elif conn.status == psutil.CONN_TIME_WAIT:
        return "Waiting for a connection to close."
    elif conn.status == psutil.CONN_CLOSE_WAIT:
        return "Waiting for a local socket to close."
    elif conn.status == psutil.CONN_LAST_ACK:
        return "Waiting for the final acknowledgment of a closed connection."
    elif conn.status == psutil.CONN_LISTEN:
        return "Listening for incoming connections."
    elif conn.status == psutil.CONN_CLOSING:
        return "Connection is closing."
    else:
        return "Unknown connection status."

def refresh_page(url):
    logging.info(Fore.YELLOW + "{=} Refreshing the page.")
    try:
        response = requests.get(url)
        if response.status_code == 200:
            logging.info(Fore.GREEN + "{+} Page refreshed successfully.")
        else:
            logging.info(Fore.RED + "{-} Could not refresh the page.")
    except requests.exceptions.RequestException:
        logging.info(Fore.RED + "{-} Failed to refresh the page.")

def scan_html(url):
    logging.info(Fore.YELLOW + "{=} Scanning HTML content.")
    try:
        response = requests.get(url)
        if response.status_code == 200:
            logging.info(Fore.GREEN + "{+} HTML content fetched successfully.")
            print(response.text)
        else:
            logging.info(Fore.RED + "{-} Failed to fetch HTML content.")
    except requests.exceptions.RequestException:
        logging.info(Fore.RED + "{-} Failed to fetch HTML content.")

def command_listener(url, target_ips):
    while True:
        command = input("Enter a command (refresh, html, network, or quit): ").strip().lower()
        if command == "refresh":
            refresh_page(url)
        elif command == "html":
            scan_html(url)
        elif command == "network":
            logging.info(Fore.GREEN + "{+} Displaying current network connections:")
            connections = psutil.net_connections(kind='inet')
            found_connections = False
            for conn in connections:
                if conn.raddr:
                    if conn.raddr.ip in target_ips or conn.laddr.ip in target_ips:
                        found_connections = True
                        status = CONN_STATUSES.get(conn.status, "UNKNOWN")
                        description = get_connection_description(conn)
                        logging.info(Fore.GREEN + f"Network traffic: {conn.laddr.ip}:{conn.laddr.port} -> {conn.raddr.ip}:{conn.raddr.port} (Status: {status}) - {description}")
            if not found_connections:
                logging.info(Fore.RED + "{-} No network connections found.")
        elif command == "quit":
            logging.info(Fore.YELLOW + "{=} Exiting.")
            break
        else:
            logging.info(Fore.RED + "{-} Unknown command.")

def ping_website(url):
    parsed_url = urlparse(url)
    target_host = parsed_url.hostname
    while True:
        response = subprocess.run(["ping", "-n", "1", target_host], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if response.returncode == 0:
            logging.info(Fore.GREEN + "{+} Ping successful.")
        else:
            logging.info(Fore.RED + "{-} Ping failed.")
        time.sleep(10)

def main():
    urls = []
    target_ips = []

    while True:
        url = input("Please enter the URL (or type 'done' to finish): ").strip()
        if url.lower() == "done":
            break
        urls.append(url)

        if check_website(url):
            logging.info(Fore.YELLOW + "{=} Attempting to open URL.")
            logging.info(Fore.GREEN + "{+} Web URL opened.")
            logging.info(Fore.GREEN + "{+} Web URL is currently running.")
            
            parsed_url = urlparse(url)
            target_host = parsed_url.hostname
            try:
                target_ip = socket.gethostbyname(target_host)
                target_ips.append(target_ip)
                logging.info(Fore.GREEN + f"Resolved {target_host} to {target_ip}")
            except socket.gaierror:
                logging.info(Fore.RED + "{-} Could not resolve the target host.")
                return

    if target_ips:
        network_thread = threading.Thread(target=monitor_network, args=(target_ips,))
        network_thread.daemon = True
        network_thread.start()

        ping_threads = []
        for url in urls:
            ping_thread = threading.Thread(target=ping_website, args=(url,))
            ping_thread.daemon = True
            ping_threads.append(ping_thread)
            ping_thread.start()

        command_listener(urls[0], target_ips)

if __name__ == "__main__":
    main()
