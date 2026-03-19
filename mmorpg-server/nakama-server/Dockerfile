FROM heroiclabs/nakama:3.23.1

# Copy custom Lua modules
COPY src/*.lua /var/lib/nakama/modules/

# Copy compiled TypeScript modules (if any)
COPY dist/*.js /var/lib/nakama/modules/ 2>/dev/null || true

# Set environment variables
ENV NAKAMA_MODULES=/var/lib/nakama/modules

EXPOSE 7349 7350 7351

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --spider -q http://localhost:7350/ || exit 1

CMD ["nakama", "--config", "/nakama/data/nakama-config.yml"]
