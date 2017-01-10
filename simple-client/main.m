//
//  main.m
//  simple-client
//
//  Created by Michael Roebuck on 3/16/16.
//  Copyright © 2016 Michael Roebuck. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>

#define PORT_TIME       13              /* "time" (not available on RedHat) */
#define PORT_FTP        5020              /* FTP connection port */
#define SERVER_ADDR     "192.168.200.86"     /* localhost */
#define MAXBUF          4096

int testSimpleClient() {
    int sockfd;
    struct sockaddr_in dest;
    char buffer[MAXBUF];
    
    /*---Open socket for streaming---*/
    printf("Opening connection...\n");
    if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 )
    {
        perror("Failed to open connection.\n");
        exit(errno);
    }
    
    /*---Initialize server address/port struct---*/
    printf("Initializing server address/port...\n");
    bzero(&dest, sizeof(dest));
    dest.sin_family = AF_INET;
    dest.sin_port = htons(PORT_FTP);
    if ( inet_aton(SERVER_ADDR, &dest.sin_addr.s_addr) == 0 )
    {
        perror("Failed to initialize server.");
        exit(errno);
    }
    
    /*---Connect to server---*/
    printf("Connecting to server...\n");
    if ( connect(sockfd, (struct sockaddr*)&dest, sizeof(dest)) != 0 )
    {
        perror("Error connecting to server.\n");
        exit(errno);
    }
    
    /*---Get "Hello?"---*/
    printf("Retrieving data...\n");
    bzero(buffer, MAXBUF);
    recv(sockfd, buffer, sizeof(buffer), 0);
    printf("data=[%s]\n", buffer);
    
    /*---Clean up---*/
    close(sockfd);
    printf("Connection closed.\n");
    return 0;
}

int testPortClient() {
    int sockfd, bytes_read;
    struct sockaddr_in dest;
    char buffer[MAXBUF];
    
    /*---Create socket for streaming---*/
    if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 )
    {
        perror("Socket");
        exit(errno);
    }
    
    /*---Initialize server address/port struct---*/
    bzero(&dest, sizeof(dest));
    dest.sin_family = AF_INET;
    if ( inet_aton(SERVER_ADDR, &dest.sin_addr.s_addr) == 0 )
    {
        perror("Failed to initialize server.");
        exit(errno);
    }
    dest.sin_port = htons(PORT_FTP);
    
    /*---Connect to server---*/
    if ( connect(sockfd, (struct sockaddr *)&dest, sizeof(dest)) != 0 )
    {
        perror("Connect");
        exit(errno);
    }
    
    /*---If there is a message to send server, send it with a '\n' (newline)---*/
    sprintf(buffer, "Blah Blah Blah!\n");
    send(sockfd, buffer, strlen(buffer), 0);
    
    /*---While there's data, read and print it---*/
    do
    {
        bzero(buffer, MAXBUF);
        bytes_read = recv(sockfd, buffer, MAXBUF, 0);
        if ( bytes_read > 0 )
            printf("%s", buffer);
    }
    while ( bytes_read > 0 );
    
    /*---Clean up---*/
    close(sockfd);
    return 0;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        testSimpleClient();
        testPortClient();
    }
    return 0;
}
