package com.peach.all.exception;

/**
 * @author feitao.zt
 * @date 2023/3/30
 */
public class PeachException extends RuntimeException {

    private static final long serialVersionUID = -3995015212822328007L;

    public PeachException(String msg) {
        super(msg);
    }

    public PeachException(String msg, Throwable throwable) {
        super(msg, throwable);
    }
}
