import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

headers = {
    'Accept-Language': 'en-US,en;q=0.5',
}

def get_movie_data(movie_div):
    try:
        movie_name = movie_div.find('a')['title']
        release_date = movie_div.find('p', class_='').text.strip()
        review = movie_div.find('div', class_="user_score_chart")['data-percent']
        movie_url = "https://www.themoviedb.org" + movie_div.find('a')['href']
        
        movie_response = requests.get(movie_url, headers=headers)
        movie_response.raise_for_status()
        
        movie_soup = BeautifulSoup(movie_response.text, 'lxml')
        
        duration = movie_soup.find('span', class_='runtime').text.strip() if movie_soup.find('span', class_='runtime') else 'N/A'
        genres = ', '.join([genre.text.strip() for genre in movie_soup.find_all('span', class_='genres')]) if movie_soup.find_all('span', class_='genres') else 'N/A'
        director = movie_soup.find('li', class_='profile').find('a').text.strip() if movie_soup.find('li', class_='profile') else 'N/A'
        
        return {
            'movie_name': movie_name,
            'release_date': release_date,
            'review': review,
            'duration': duration,
            'genres': genres,
            'director': director
        }
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred while fetching {movie_url}: {http_err}")
   
    return {
        'movie_name': movie_name,
        'release_date': release_date,
        'review': review,
        'duration': 'N/A',
        'genres': 'N/A',
        'director': 'N/A'
    }

def fetch_movies_from_page(page_number):
    url = f"https://www.themoviedb.org/movie?page={page_number}"

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
   
    return None

def scrape_movies(max_movies=1000):
    movies_data = []
    page_number = 1

    while len(movies_data) < max_movies:
        res = fetch_movies_from_page(page_number)
        if res is None:
            print(f"Skipping page {page_number} due to a fetch error.")
            page_number += 1
            time.sleep(1)
            continue
        soup_data = BeautifulSoup(res.text, 'lxml')
        movie_divs = soup_data.find_all('div', class_="card style_1")
        
        for movie_div in movie_divs:
            if len(movies_data) >= max_movies:
                break
            movie_info = get_movie_data(movie_div)
            movies_data.append(movie_info)

        page_number += 1
        time.sleep(1)

    return movies_data

def save_to_csv(movies_data, filename='tmdb_movies.csv'):
    df = pd.DataFrame(movies_data)
    df.to_csv(filename, index=False)
    print(f"Data saved to {filename}")


movies_data = scrape_movies()
save_to_csv(movies_data)