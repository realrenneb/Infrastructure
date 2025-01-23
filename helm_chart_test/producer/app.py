from flask import Flask
import threading
import logging
import time
import random

app = Flask(__name__)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

running = True

def custom():
    """
    You CAN ADD your functionality here.
    """

def extra():
    """
    Extra thread for any customazation needed.
    DO NOT TOUCH THIS FUNCTION
    """
    while True:
        custom()

def produce_events():
    """
    Event producer function that imitates event generation.
    To keep it simple it just logs the message "Produced X events".
    In fact nothing is being produced.
    DO NOT TOUCH THIS FUNCTION
    """
    hang_time = random.randint(5, 10) * 60
    start_time = time.time()
    sleep_time = random.randint(1, 30)
    while running:
        time.sleep(sleep_time)
        if time.time() - start_time >= hang_time:
            logging.info("App has hung. No more events will be produced.")
            break

        event_count = random.randint(10, 1000)
        logging.info(f"Produced {event_count} events")

main_thread = threading.Thread(target=produce_events)
main_thread.daemon = True
main_thread.start()

extra_thread = threading.Thread(target=extra)
extra_thread.daemon = True
extra_thread.start()


@app.route('/')
def home():
    return "Flask app is running and producing events. It will hang after some time.\n"

if __name__ == '__main__':
    app.run(debug=True)