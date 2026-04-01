#!/usr/bin/env python3
import os
import sys
import email
from email import policy
from weasyprint import HTML

def mostrar_ayuda():
    print(f"Uso: {sys.argv[0]} /ruta/al/directorio")
    print("Convierte archivos .eml a PDF usando WeasyPrint (maneja HTML e imágenes)")

def extraer_html_eml(ruta_eml):
    with open(ruta_eml, 'rb') as f:
        msg = email.message_from_binary_file(f, policy=policy.default)

    html = None
    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == 'text/html':
                html = part.get_content()
                break
    else:
        if msg.get_content_type() == 'text/html':
            html = msg.get_content()
    return html

def procesar_directorio(directorio):
    dir_pdf = os.path.join(directorio, "pdf")
    os.makedirs(dir_pdf, exist_ok=True)

    for archivo in os.listdir(directorio):
        if archivo.lower().endswith('.eml'):
            ruta_eml = os.path.join(directorio, archivo)
            ruta_pdf = os.path.join(dir_pdf, archivo + '.pdf')
            print(f"Procesando {archivo} → pdf/{archivo+'.pdf'}")
            try:
                html = extraer_html_eml(ruta_eml)
                if not html:
                    print(f"Advertencia: no se encontró parte HTML en {archivo}, omitiendo.")
                    continue
                HTML(string=html).write_pdf(ruta_pdf)
            except Exception as e:
                print(f"Error en {archivo}: {e}")

def main():
    if len(sys.argv) != 2:
        mostrar_ayuda()
        sys.exit(1)
    directorio = sys.argv[1]
    if not os.path.isdir(directorio):
        print(f"Error: '{directorio}' no es un directorio válido")
        sys.exit(1)
    procesar_directorio(directorio)

if __name__ == '__main__':
    main()
