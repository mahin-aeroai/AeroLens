# ── AeroERP .NET 8 Web API — Dockerfile ──────────────────────
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY backend/ ./backend/

# Create minimal .NET 8 project structure for Railway
WORKDIR /src/backend

# Create a self-contained .csproj if not present
RUN cat > AeroERP.API.csproj << 'CSPROJ'
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Oracle.ManagedDataAccess.Core" Version="23.5.1" />
    <PackageReference Include="Dapper" Version="2.1.35" />
    <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.6" />
    <PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.7.3" />
  </ItemGroup>
</Project>
CSPROJ

RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "AeroERP.API.dll"]
