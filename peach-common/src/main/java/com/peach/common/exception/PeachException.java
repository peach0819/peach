package com.peach.common.exception;

public class PeachException extends RuntimeException {

    public PeachException(String msg) {
        super(msg);
    }

    public PeachException(String msg, Throwable throwable) {
        super(msg, throwable);
    }
}
