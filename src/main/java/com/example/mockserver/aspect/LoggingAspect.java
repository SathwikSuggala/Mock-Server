package com.example.mockserver.aspect;

import com.example.mockserver.service.SettingsService;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Aspect
@Component
public class LoggingAspect {

    private static final Logger log = LoggerFactory.getLogger(LoggingAspect.class);
    private final SettingsService settingsService;

    public LoggingAspect(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    private boolean isLoggingEnabled() {
        return "true".equals(settingsService.get("system.logging.enabled", "false"));
    }

    @Around("(execution(* com.example.mockserver.service..*(..)) || execution(* com.example.mockserver.controller..*(..))) && !target(com.example.mockserver.service.SettingsService)")
    public Object logMethodExecution(ProceedingJoinPoint joinPoint) throws Throwable {
        if (!isLoggingEnabled()) {
            return joinPoint.proceed();
        }

        String methodName = joinPoint.getSignature().getDeclaringTypeName() + "." + joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        
        log.info("Enter: {}() with arguments = {}", methodName, args);
        long start = System.currentTimeMillis();

        try {
            Object result = joinPoint.proceed();
            long elapsedTime = System.currentTimeMillis() - start;
            log.info("Exit:  {}() completed in {} ms with result = {}", methodName, elapsedTime, result);
            return result;
        } catch (IllegalArgumentException e) {
            log.error("Illegal argument: {} in {}()", Arrays.toString(args), methodName);
            throw e;
        } catch (Throwable e) {
            log.error("Exception in {}(): {}", methodName, e.getMessage(), e);
            throw e;
        }
    }
}
