def enviaArquivo(path):
    from ftplib import FTP 
    import os
    import fileinput
    ftp = FTP()
    ftp.set_debuglevel(2)
    ftp.connect('cobrinha-do-mito.freetzi.com', 21) 
    ftp.login('cobrinha-do-mito.freetzi.com','32431404')
    ftp.cwd('/uploads')
    fp = open("/home/cpires/paperDoCoracao/uffgpu2019/PROJETO/"+path, 'rb')
    ftp.storbinary('STOR %s' % os.path.basename("/home/cpires/paperDoCoracao/uffgpu2019/PROJETO/"+path), fp, 1024)

enviaArquivo("graficosParaPlotar.txt")

#ftp://cobrinha-do-mito.freetzi.com:32431404@ftp.cobrinha-do-mito.freetzi.com