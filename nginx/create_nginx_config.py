from string import Template
import os


def main():
    template_vars = {
        'SERVER_NAME': os.environ.get('NGINX_SERVER_NAME', '')
    }
    nginx_dir = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(nginx_dir, 'elsword-guide.conf'), 'r') as f:
        src = Template(f.read())
        result = src.substitute(template_vars)

        with open('/etc/nginx/conf.d/elsword-guide.conf', 'w') as fw:
            fw.write(result)


if __name__ == '__main__':
    main()
