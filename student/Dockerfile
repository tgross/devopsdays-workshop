# student/Dockerfile describes the environment that workshop students
# will have when they ssh into a workshop host.

FROM student-base

# clone the workshop and make sure we've set up a bash profile
# with the appropriate environment setup
RUN git clone https://github.com/tgross/devopsdays-workshop /root/workshop
COPY .bash_aliases  /root/.bash_aliases

WORKDIR /root/workshop
CMD [ "/bin/bash" ]
